.\newline\newline\newline\newline\newline\newline\newline\newline

<br>

# **Camelot RReport Documentation**

### [Camelot RReport web application](https://shiny.vef.hr/){target="_blank"}

<br>

#### **Introduction**

Camera traps have emerged as indispensable tools for studying wildlife in their natural environments. By employing motion-sensing technology, camera traps capture images and videos of various species, offering researchers to record their presence, activity patterns or behaviour. Through the analysis of these data, scientists can gain deeper insights into species abundance, habitat preferences, and their interactions. Moreover, camera trapping enables the monitoring of elusive or endangered species, helping in the development of targeted conservation strategies. However, camera trapping can generate extensive datasets, which require efficient softwares for data management to enable further analyses.

<br>

#### **About Camelot**

Camelot is an open-source camera trapping software ([camelotproject.org](https://camelotproject.org/){target="_blank"}), for wildlife researchers and conservationists. Camelot enables efficient classification of camera trap photos, keeping track of camera traps activity and positioning in the field, and management of recorded species data. Camelot also has the possibility of creating reports (exports in .cvs format), allowing users to efficiently extract structured data. However, its functionality falls short in terms of comprehensive data analysis reporting. While Camelot does offer some calculated columns, its reporting features are limited, providing only sparse analytical insights compared to more advanced data analysis tools. Users then need to integrate Camelot’s data exports with other reporting solutions for a more thorough analysis of extracted data.

<br>

#### **About RReport**

[RReport](https://shiny.vef.hr/ "RReport server"){target="_blank"} is an open-source web application designed through a customized R script to integrate with Camelot, using Camelot’s data exports to generate more advanced analyses. RReport enhances data insights and visualization capabilities beyond Camelot’s native functionalities.

<br>

## **How to use**

To use RReport, you require a Camelot *Full export* report, which can be generated and exported via the *Reports* section within Camelot.

![](imag/full_export.jpg)

<br>

## **1. Login**

To access the RRreport you need to define and type in a login username by choice that will be linked to your data. Login username must not contain space, separators or uncommon letters. By logging in, theapplication creates a unique folder under this username which will be used for storing uploded data, and created reports,tables and graphs.Users can delete this folder or it will be automatically deleted in 7 days after the last access.

Each username can be linked with only one data upload. In case you want to create a new report with a new dataset, a different login username must be entered (you can use the same username following a number without space, e.g. username, username1, username2, etc.)

If you type in an existing username – it skips the upload interface and jumps directly to the report’s Results.

<br>

## **2. File upload**

The interface for uploading data consists of the:

-   **Time zone** (default UTC ): choose the TM, [list of TZ](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones "List of time zone"){target="_blank"}

-   **Temporal discretization** (default 600 seconds): used to discretise events - the period of time between independent triggers ([Camelot manual, section Reports](https://camelot-project.readthedocs.io/en/latest/reports.html "Independent observations"){target="_blank"}) of distinct individuals. While the ideal interval for defining independent events has not been empirically determined using camera traps, it generally falls between 10 and 60 minutes, with shorter intervals of 1-5 minutes often applied to small mammals. Nevertheless, certain analyses, including occupancy modeling, capture-recapture studies, or examining movement patterns, may set intervals extending to one or more days.

-   **Start date**: starting date for data analysis

-   **End date**: end date for data analysis

-   **Survey 1 – 5**: A survey in Camelot represents a research project and will contain details about your camera traps and uploaded images. Camelot allows for creation of multiple surveys which are all included in the Camelot Full export file. If you want to omit data from a certain survey from the analysis, enter in optional boxes the names of surveys that you want to include. If you want to use data from all surveys you can leave the area empty.

-   **Choose file**: choose the downloaded Camelot *Full export* from your computer

![](imag/upload_full_export.jpg)

<br>

## **3. Results**

<br>

#### **TAB 1. Original data**

-   Raw upload of the *Full export* CSV file from Camelot

<br>

#### **TAB 2. Trap Stations:**

-   2.1. Trap station location: map of camera trap locations – downloadable as a GPKG file for GIS.

-   2.2. Trap station interval: interval within which each camera trap was continuously working in the field without interrumptions. If the camera trap interval falls inside of the time filter set by the *Start* and *End* date from the *Upload interface*, it shows the Start and End date of the whole session.

-   2.3. Trap station activity per month: sum of active days per session followed by the number of active days per month

-   2.4. Trap station activity per month SUM: sum of the table under 2.3, used for calculating *3.1. Species list and count*

<br>

#### **TAB 3. Events / Species**

-   3.1. Species list and count: species occurrence per camera trap per month

-   3.2. Temporal discretisation: data filtered by species and temporal disretisation with the information on the moon illumination/solar time (0.25 dawn, 0.5 middle of the day, 0.00 & 1.00 middle of the night).<br><br>
Dusk and dawn are calculated with the R package [suncalc](https://cran.r-project.org/web/packages/suncalc/suncalc.pdf "R package suncalc"){target="_blank"}. Dusk and dawn are defined according to civil twilight, where dawn represents the point when the Sun is 6° below the horizon on the eastern side, and dusk represents the point when the Sun is 6° below the horizon on the western side. The time of each event is expressed relative to these two points. This information is used for calculating species' daily activity (*Tab 4. – 4.4. Graph daily activity*).<br><br>
Animals were determined as *adults* if no other information (*subadult* or *juvenile*) was available from the Camelot species identification process. Sex was not taken into account.

-   3.3. Temporal discretisation full: same as *3.2. Temporal discretisation* with all data included from the *Full export* (original data discretised).

<br>

#### **TAB 4. Abundance change / Activity**

-   4.1. Graph species activity per years

-   4.2. Graph species activity per sum months

-   4.3. Graph species activity per months / year

-   4.4. Graph daily activity

-   4.5. Species activity per years

-   4.6. Species activity per sum months

-   4.7. Species activity per months / years

<br>

<br>

Citate: Gomerčić, T., I. Topličanec, M. Sindičić, V. Šimunović (2024): ........

GitHub: <https://github.com/Gomercic/Camelot_RReport>

Contact: tomislav.gomercic\@vef.unizg.hr

University of Zagreb, Faculty of Veterinary Medicine, Zagreb, Croatia
