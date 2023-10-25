# Configuration

The `ADO` and `GitHub` folders contain the corresponding configuration template for the given platform. The following is how the sssc.env file is created and used throughout the walkthrough.

1. The configuration template file, `.configtemplate`, is copied to sssc.config.
1. `sssc.config` is manually updated with the proper values by the user of the walkthrough.
1. `sssc.env` is created from `sssc.config`
1. When the init script is run during the deployment, `sssc.env` will will be backfill with additional values.
1. `sssc.env` is also dynamically updated with values as they are generated throughout the walkthrough. As values are added to the file they are exported so they will be available to all sessions.

> [!NOTE]
> For further information on the specific environment variables created and used, please see [this document](environment.md)
