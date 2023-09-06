*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.

Library    RPA.HTTP
Library    RPA.Tables
Library    OperatingSystem
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.PDF
Library    RPA.Archive

*** Variables ***
${ORDERS}    https://robotsparebinindustries.com/orders.csv 


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Open the robot order website
    Fill form(${row})


*** Keywords ***
Open the robot order website
    Download    ${ORDERS}    overwrite=True
    ${table}=    Read Table From CSV    orders.csv
    FOR    ${row}    IN    @{table}
        Fill form    ${row}  
        Create receipt    ${row} 
    END
    Archive Folder With Zip    output    outputzip.zip
    Close Browser
    
Fill form 
    [Arguments]    ${row}
    Go To    https://robotsparebinindustries.com/#/robot-order
            Click Button    class:btn-dark
            Select From List By Value    //*[@id="head"]    ${row}[Head]
            Click Element    id-body-${row}[Body]
            Input Text    //*[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
            Input Text    //*[@placeholder="Shipping address"]    ${row}[Address]
            Sleep    0.25 sec
            Click Button    //*[@id="order"]
            

Create receipt
    [Arguments]    ${row}
    ${visible}=    Run Keyword And Return Status    Element Should Be Visible    //*[@id="receipt"]
    WHILE    ${visible} == False
        Click Button    //*[@id="order"]
        ${visible}=    Run Keyword And Return Status    Element Should Be Visible    //*[@id="receipt"]
    END
    # Wait Until Page Contains Element    //*[@id="receipt"]  
    ${sales_results_html}=    Get Element Attribute    //*[@id="receipt"]   outerHTML
    Html To Pdf    ${sales_results_html}    output/results/sales_results${row}[Head].pdf
    
    
    
    

