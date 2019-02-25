/* sample parameter cursor program */
Declare 
  Cursor Emp_Curr(P_Deptno Number)Is Select Last_Name,Salary From Employees
  Where Department_Id=P_Deptno;
  Emp_Rec Emp_Curr%Rowtype;
Begin
  Open Emp_Curr(50);
  Loop
  Fetch Emp_Curr Into Emp_Rec;
  Exit When Emp_Curr%Notfound;
  dbms_output.put_line(Emp_Rec.last_name||' '||emp_rec.salary);
  End Loop;
  Close Emp_Curr;
end;

  