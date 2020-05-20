import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import {TestComponent} from "./test/test.component";
import {AuthComponent} from "./auth/auth.component";
import {AuthGuard} from "./auth.guard";


const routes: Routes = [
  {
    path: '',
    redirectTo: 'test',
    pathMatch: "full"
  },
  {
    path: "auth",
    component: AuthComponent
  },
  {
    path: "test",
    component: TestComponent,
    canActivate: [AuthGuard]
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
