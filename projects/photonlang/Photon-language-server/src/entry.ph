import 'Microsoft/AspNetCore/Hosting';
import 'Microsoft/AspNetCore/Builder';
import 'Microsoft/AspNetCore/Http';

const host = new WebHostBuilder().UseKestrel().UseStartup<Startup>().UseUrls('http://localhost:8080').Build();

host.Run();

export class Startup {
    public Configure(app: IApplicationBuilder): void {
        app.Run((context) => {
            return context.Response.WriteAsync('Hello, World!');
        });
    }
}
