/*taking dept no  from department table and used that dept no and print the emp last_name and salary of employees */
Declare 
  Cursor C Is Select Department_Id From Departments;
  Cursor Dept_Curr(P_Deptno number)Is Select Last_Name,Salary From Employees
  where department_id=P_Deptno;
  V_Deptno Number;
  emp_rec Dept_Curr%rowtype;
Begin
    Open C;
    Loop
    Fetch C Into V_Deptno;
    Exit When C%Notfound;
        Open Dept_Curr(V_Deptno);
        Loop 
        Fetch Dept_Curr Into Emp_Rec;
        Exit When Dept_Curr%Notfound;
        dbms_output.put_line(emp_rec.last_name||' '||emp_rec.salary);
        End Loop;
        Close Dept_Curr;
    End Loop;
   close c;
end;
/