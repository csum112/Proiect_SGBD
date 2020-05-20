import {Component, OnInit} from '@angular/core';
import {CookieService} from "ngx-cookie-service";
import {HttpClient} from "@angular/common/http";
import {Observable} from "rxjs";

@Component({
    selector: 'app-test',
    templateUrl: './test.component.html',
    styleUrls: ['./test.component.scss']
})
export class TestComponent implements OnInit {
    host = window.location.origin;
    API = `${this.host}/api/questions`;
    email: string;
    hash: string;
    qid: string;
    qos: Observable<any>;
    answers = {
        '1': false,
        '2': false,
        '3': false,
        '4': false,
        '5': false,
        '6': false,
    };

    constructor(private cs: CookieService, private http: HttpClient) {
        this.email = this.cs.get("email");
        this.hash = this.cs.get("hash");
        this.fetchQuestion();
    }

    ngOnInit(): void {

    }

    getAns() {
        let arr = [];
        for (let answersKey in this.answers) {
            if (this.answers[answersKey] == true)
                arr.push(parseInt(answersKey));
        }
        return arr;
    }

    submitAnswer() {
        let a = this.getAns();
        console.log(a)
        this.qos = this.http.post(this.API, {
            email: this.email,
            hash: this.hash,
            questionId: this.qid,
            answers: a,
        }, {
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": '*'
            }
        });
        this.qos.toPromise().then(q => {this.qid = q.questionId});
        this.answers = {
            '1': false,
            '2': false,
            '3': false,
            '4': false,
            '5': false,
            '6': false,
        };
    }

    fetchQuestion() {
        this.qos = this.http.post(this.API, {
            email: this.email,
            hash: this.hash
        }, {
            headers: {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": '*'
            }
        });
        this.qos.toPromise().then(q => {this.qid = q.questionId});
    }
}
