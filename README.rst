=============================
Rest server for SSTU schedule
=============================

This ruby application implement rest API for Saratov State Technical University (SSTU) schedule_

*********************
Implemented functions
*********************
+ Parser for group mode
+ Parser for department mode
+ Parser for classroom mode
+ Parser for lecturer mode

********************
Examples of requests
********************

- Group mode

  ``http://{ip}:{port}/group=б1-ИВЧТ41``

- Department mode

  ``http://{ip}:{port}/kafedra=ИСТ``

  - Subquery with lecturer

    ``http://{ip}:{port}/kafedra=ИСТ/lector=Глухова+РМ``
    
- Classroom mode

  ``http://{ip}:{port}/aud=1+420``
    
- Lecturer mode

  ``http://{ip}:{port}/lector=Глухова+РМ``



+---------------------+-----------+
|**What I try to add**|**Status** |
+---------------------+-----------+
|Secure connection    |Temporarily|
|(HTTPS)              |unavailable|
+---------------------+-----------+
|API Key              |Not        |
|authorization        |Started    |
+---------------------+-----------+



.. _schedule: http://rasp.sstu.ru
