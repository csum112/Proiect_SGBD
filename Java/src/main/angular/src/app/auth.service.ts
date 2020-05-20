import {Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {Observable} from "rxjs";
import {CookieService} from "ngx-cookie-service";
import {Route, Router} from "@angular/router";

interface Resp {
    hash: string,
    ok: boolean
}


@Injectable({
    providedIn: 'root'
})
export class AuthService {
    host = window.location.origin;
    API = `${this.host}/api/auth`;

    constructor(private http: HttpClient, private cs: CookieService, private router: Router) {
    }

    tryToAuth(email: string) {
        const h = new Headers();
        const response = this.http.post<string>(this.API, email, {
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": '*'
            }
        });
        response.subscribe(data => {
                this.cs.set("email", email);
                this.cs.set("hash", data);
                console.log("Okay, logged in")
                this.router.navigate(['test']);
            },
            error => console.log);
    }
}
