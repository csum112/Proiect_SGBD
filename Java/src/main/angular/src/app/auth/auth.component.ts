import {Component, OnInit} from '@angular/core';
import {AuthService} from "../auth.service";

@Component({
    selector: 'app-auth',
    templateUrl: './auth.component.html',
    styleUrls: ['./auth.component.scss']
})
export class AuthComponent implements OnInit {
    email: string;

    constructor(private as: AuthService) {
    }

    ngOnInit(): void {
    }

    tryAuth() {
        this.as.tryToAuth(this.email);
    }

}
