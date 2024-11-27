**A basic ABAP report which will display information from the SFLIGHT table.**

Selection screen has radio buttons labeled report A, Report B.\
When switching between the two radio buttons the parameters change.

**Report A:**
- Dynamic selection screen parameters: CARRID, CONNID, FLDATE, PLANETYPE
- Selection fields are displayed along with the PRICE, SEATSMAX, SEATSOCC
- If a planes SEATSOCC is within 75% capacity of the SEATSMAX, displays that entire row as yellow
- If a planes SEATSOC is within 90% capacity of the SEATSMAX, displays it in orange
- If the plane is full, displays it in red
*Completed in a conventional report (write statements)

**Report B:**
- Dynamic selection screen parameters:  FLDATE, BOOKID, Customer Name, CUSTTYPE
- The report is implemented in an ALV, utilizing an SALV
- The ALV displays the following columns from tables SBOOK, and SCUSTOM: FLDATE, CARRID, CUSTTYPE, PASSNAME, PASSADDRESS, EMAIL, and BOOKED
- Before displaying each row in the ALV, 3 years are added to the FLDATE
- Custom table called YZBOOKINGS_AO created
- The table has columns, CARRID, CONNID, FLDATE, BOOKID, CUSTTYPE, PASSNAME, PASSADDRESS, EMAIL
- The table's key fields are the first 4 fields described above
- Each row should has a checkbox, and the ALV has a button to “Book” the flight
- When a row is selected and the button “Book” is hit, an entry is created in the custom table YZBOOKINGS_AO and the BOOKED field set to ‘X’
- Also, the passenger's name is changed to the username’s first and last name
- When displaying the ALV and booked is set to X, the custom table is checked for the passenger's name instead of the SBOOK table
