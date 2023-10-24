package tripsgo

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/Azure/go-autorest/autorest/adal"
	mssql "github.com/denisenkom/go-mssqldb"
)

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func writeConfigMessage(name string, value string, srcType string, src string) {
	msg := ""
	if value == "" {
		msg = "no "
	}
	fmt.Printf("Config '%s' has %s value set from %s '%s'.\n", name, msg, srcType, src)
}

func getConfigValue(name string, fallback string) string {
	value := ""

	configFilesPath := getEnv("CONFIG_FILES_PATH", "/secrets")
	filePath := filepath.Join(configFilesPath, name)
	filevalue, _ := ioutil.ReadFile(filePath)
	value = string(filevalue)
	writeConfigMessage(name, value, "file", filePath)

	if value == "" {
		value = getEnv(name, fallback)
		writeConfigMessage(name, value, "ENV", name)
	}

	return value
}

var (
	debug             = flag.Bool("debug", false, "enable debugging")
	password          = flag.String("password", getConfigValue("SQL_PASSWORD", "changeme"), "the database password")
	user              = flag.String("user", getConfigValue("SQL_USER", "sqladmin"), "the database user")
	port              = flag.Int("port", 1433, "the database port")
	server            = flag.String("server", getConfigValue("SQL_SERVER", "changeme.database.windows.net"), "the database server")
	database          = flag.String("d", getConfigValue("SQL_DBNAME", "mydrivingDB"), "db_name")
	credential_method = flag.String("c", getConfigValue("CREDENTIAL_METHOD", "username_and_password"), "method of authenticating into SQL DB")
	clientId          = flag.String("i", getConfigValue("IDENTITY_CLIENT_ID", ""), "the  identity client id")
)

func getTokenProvider() (func() (string, error), error) {

	options := adal.ManagedIdentityOptions{
		ClientID: *clientId,
	}

	resource := "https://database.windows.net/"

	msi, err := adal.NewServicePrincipalTokenFromManagedIdentity(resource, &options)

	if err != nil {
		return nil, err
	}

	return func() (string, error) {
		msi.EnsureFresh()
		token := msi.OAuthToken()
		return token, nil
	}, nil
}

func getDBConnection() (*sql.DB, error) {
	var conn *sql.DB

	switch *credential_method {

	case "managed_identity":
		connectionString := fmt.Sprintf("Server=%s;Database=%s", *server, *database)

		tokenProvider, err := getTokenProvider()
		if err != nil {
			logError(err, "Error creating token provider for system assigned Azure Managed Identity:")
		}

		accessTokenConnection, err := mssql.NewAccessTokenConnector(connectionString, tokenProvider)
		if err != nil {
			logError(err, "Error establishing DB connection using a managed identity")
			return nil, err
		}
		conn = sql.OpenDB(accessTokenConnection)

	case "username_and_password":
		connectionString := fmt.Sprintf("server=%s;database=%s;user id=%s;password=%s;port=%d", *server, *database, *user, *password, *port)

		if *debug {
			fmt.Printf("connString:%s\n", connectionString)
		}
		usernameAndPasswordConnection, err := sql.Open("mssql", connectionString)
		if err != nil {
			logError(err, "Error creating MSSQL Connection using UserName and Password")
			return nil, err
		}
		conn = usernameAndPasswordConnection
	}
	return conn, nil
}

// ExecuteNonQuery - Execute a SQL query that has no records returned (Ex. Delete)
func ExecuteNonQuery(query string) (string, error) {
	conn, err := getDBConnection()
	if err != nil {
		return "", err
	}
	defer conn.Close()

	statement, err := conn.Prepare(query)

	if err != nil {
		return "", err
	}

	defer statement.Close()

	result, err := statement.Exec()

	if err != nil {
		return "", err
	}

	serializedResult, _ := json.Marshal(result)

	return string(serializedResult), nil
}

// ExecuteQuery - Executes a query and returns the result set
func ExecuteQuery(query string) (*sql.Rows, error) {
	conn, err := getDBConnection()
	if err != nil {
		return nil, err
	}
	defer conn.Close()

	statement, err := conn.Prepare(query)

	if err != nil {
		return nil, err
		// log.Fatal("Failed to query a trip: ", err.Error())
	}

	defer statement.Close()

	rows, err := statement.Query()

	if err != nil {
		return nil, err
		// log.Fatal("Error while running the query: ", err.Error())
	}

	return rows, nil
}

// FirstOrDefault - returns the first row of the result set.
func FirstOrDefault(query string) (*sql.Row, error) {
	connString := fmt.Sprintf("server=%s;database=%s;user id=%s;password=%s;port=%d", *server, *database, *user, *password, *port)

	if *debug {
		fmt.Printf("connString:%s\n", connString)
	}

	conn, err := sql.Open("mssql", connString)

	if err != nil {
		return nil, err
		// log.Fatal("Failed to connect to the database: ", err.Error())
	}

	defer conn.Close()

	statement, err := conn.Prepare(query)

	if err != nil {
		return nil, err
		// log.Fatal("Failed to query a trip: ", err.Error())
	}

	defer statement.Close()

	row := statement.QueryRow()

	return row, nil
}
