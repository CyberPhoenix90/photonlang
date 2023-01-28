import 'Microsoft/AspNetCore/Hosting';
import 'Microsoft/AspNetCore/Builder';
import 'Microsoft/AspNetCore/Http';

const host = new WebHostBuilder().UseKestrel().UseStartup<Startup>().UseUrls('http://localhost:8080').Build();

host.Run();

//prettier-ignore
[Route('api/[controller]')]
[ApiController]
export class GreetingController extends ControllerBase {
    //prettier-ignore
    [HttpGet('{name}')]
    public Get(name: string): ActionResult<string> {
        return `Hello, ${name}!`;
    }
}

export class Startup {
    public Configure(app: IApplicationBuilder, env: IWebHostEnvironment): void {
        if (env.IsDevelopment()) {
            app.UseDeveloperExceptionPage();
        }
        app.UseRouting();
        app.UseEndpoints((endpoints) => {
            endpoints.MapControllers();
        });
        app.Run();
    }
}
