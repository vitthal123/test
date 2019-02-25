/*Tenant (tenantID*, password, SSN, firstname, lastname, 
email, phone, currentAddress, cityStateZip, password)
*/
CREATE TABLE Tenant
(       tenantID NUMBER PRIMARY KEY, 
        PASSWORD VARCHAR(15),
        firstname VARCHAR(15),
        lastname VARCHAR(15),
        email VARCHAR2(30),
        mobileno VARCHAR2(12),
        address VARCHAR2(100),
        district VARCHAR2(20),  
        pincode VARCHAR2(6)
); 

/*Lease (leaseID, startDate, endDate, balance, securityDeposit, 
rentalDate, tenatId*, apartmentNumber*, terminationID*, apartmentChangeID*)*/

CREATE TABLE lease 
 (       leaseid NUMBER,
         startdate DATE,
         enddate DATE,
         debosite NUMBER(8,2),
         tenatid NUMBER REFERENCES Tenant(tenantid)
);
 
/* Renewal (renewalID, renewalDate, renewalPeriod, leaseID*)*/
CREATE TABLE Renewal 
(    renewalID NUMBER PRIMARY KEY, 
     renewalDate DATE, 
     renewalPeriod NUMBER, 
     leaseid NUMBER REFERENCES lease(leaseid)
);   

/* Termination(terminationID, leavingDate, leavingReason ,)*/

CREATE TABLE Termination 
(    terminationid NUMBER,
     leavingDate DATE,
     leavingReason VARCHAR2(100)
);

/*Rent (rentID, rentalFee, lateFee, date, dateToPay, leaseID*, payID*)*/

CREATE TABLE Rent
(   rentID NUMBER,
    rentalFee NUMBER(8,2),
    rentaldate DATE,
    leaseID NUMBER REFERENCES lease(leaseid),
);

/* Payment (payID, payDate, payAmount, payMethod, rentID*) */

CREATE TABLE Payment 
(    payID NUMBER , 
     payDate DATE, 
     payAmount NUMBER(8,2), 
     payMethod VARCHAR2(20), 
     rentID NUMBER REFERENCES Rent(rentID)
);
