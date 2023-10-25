using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Rewrite;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.OpenApi.Models;

namespace poi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc();
            var connectionString = poi.Utility.POIConfiguration.GetConnectionString(this.Configuration);

            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("docs", new OpenApiInfo { Title = "Trip Insights Points Of Interest (POI) API", Description = "API for the trips in the Trip Insights app. https://github.com/microsoft/secure-software-supply-chain-on-aks", Version = "v1" });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILogger<Startup> logger)
        {
            app.UseRewriter(new RewriteOptions().AddRedirect("(.*)api/docs/poi$", "$1api/docs/poi/index.html"));

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger(c =>
                c.RouteTemplate = "swagger/{documentName}/poi/swagger.json"
            );

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.),
            // specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/docs/poi/swagger.json", "Trip Insights Points Of Interest (POI) API V1");
                c.DocumentTitle = "POI Swagger UI";
                c.RoutePrefix = "api/docs/poi";
            });
        }
    }
}
