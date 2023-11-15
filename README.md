## Clinic Scheduling application

**Your job is to design and implement the core components of an on-line scheduling application for a physiotherapy clinic. The clinic has the following business rules:**
* The clinic is open from 9am until 5pm.
* The clinic offers three types of appointments, a 90 minutes initial consultation, standard 60 minute appointments and 30 minute check-ins.
* Appointments do not overlap. There can only be one booked appointment at any time.
* Appointments start on the hour or half-hour.
* Bookings can only be made for appointments that start and end within the clinic hours.
* Bookings cannot be made within 2 hours of the appointment start time.

**The application MVP will:**

* Provide the patient with a list of available appointment times. Inputs are the appointment type and a date, either today or in the future. The 2 hour booking deadline applies for today’s appointments.
* Allow the patient to book an appointment.
* Provide the practitioner with a list of scheduled appointments for the current day.

----------
## Clinic Scheduling application assignment

### Environment
- Ruby version: 3.2.2

- System dependencies: Docker

- Configuration

- Database creation: To make things easy, this project uses SQLite3. It will be created as the tests runs.
    - If needed, database can be created by running:
        - DEV:
        - ```
      bundle exec rake db:migrate
      ```
        - TESTS:
        - ```
      RAILS_ENV=test bundle exec rake db:migration
      ```

- How to run the test suite:
    - Build docker image with:
  ```
  make build
  ```
    - Run tests with docker:
  ```
  make run-test
  ```

### Assignment

#### General explanation
- Assignment example only mentioned a single clinic, however it makes sense to me to be able to handle multiple clinics. Each clinic will have it's own practitioners, patients and bookings.
- Tests fixtures were created using the scenarios provided.
- There's no mention about limiting the number of practitioners, so there's no check for it.
- I considered appointment types as something shared by all clinics, so they wouldn't be able to customize it. If needed, we could create a table to store different appointment types and create a relationship between them.
- In this solution, patients and practitioners can be part of a single clinic, so when looking for a practitioner's availability, it considers any appointments that practitioner will have on a specific day of a clinic. The same applies for patients.
- Any appointment will check both practitioners and patients bookings.
- Clinic model could be improved by adding some memoized variables for closing/opening hour/minutes, but it would also require to probably override open_time and close_time setters to clear the variables.
- BaseService has a clinic_id requirement, which might cause too many clinic queries. I left it like this to make implementation easier, but injecting it instea of passing the ID would be a better approach.
- The general assumption is that we will have a layer of authentication at the controllers level, where after authenticating they will call the appropriate service from the service layer, where the business logic will live.
- Part of the assumption relies on the fact that the logged user will belong to a clinic, which can be passed to all services as a reference.

#### Timezone
- I am considering that each clinic can have a their own timezone.
- In order to deal with different timezones, I've decided on the following approach:
    - Datetime is saved as UTC dates in the database.
    - Clinic has an extra field called timezone, which will store the timezone as a POSIX style string.
    - The timezone value will be used to convert it back to clinic's default timezone.
    - `TimeUtils.tz` returns the correct timezone string after providing the GMT value
    - I was created to make it wasy to pass the correct POSIX string. See explanation below:
      > The special area of "Etc" is used for some administrative zones, particularly for "Etc/UTC" which represents
      Coordinated Universal Time. In order to conform with the POSIX style, those zone names beginning with "Etc/GMT"
      have their sign reversed from the standard ISO 8601 convention. In the "Etc" area, zones west of GMT have
      a positive sign and those east have a negative sign in their name (e.g "Etc/GMT-14" is 14 hours ahead of GMT).
      https://en.wikipedia.org/wiki/Tz_database#Area
- When creating an appointment and returning practitioner's agenda, it considers clinic's timezone
- It was easy to create tests data using a specific timezone.
- Tests will pass regardless of the server default timezone.
- Helper method below:
  ```
   def tz(gmt_offset)
     offset = gmt_offset[0] == '-' ? '+'.concat(gmt_offset[1..]) : '-'.concat(gmt_offset[1..])
     "Etc/GMT#{offset}"
   end
  ```
- Each class has an explanatory comment header.

#### Code separation
- I took an approach of having the business rules applied at a service/command level, leaving the models a little bit thinner. Their responsibility will be reduced to any model validation which seems necessary, and some specific methods.
- The service/command will work as a manager, calling and delegating actions to other services when necessary.
- AppointmentType was left within the models folder for the sake of simplicity, however it would be good to have specific folders to hold these complimentary classes which somehow would relate to a specific model.

#### Tests
All scenarios described were included in the tests

* The clinic is open from 9am until 5pm.
* The clinic offers three types of appointments, a 90 minutes initial consultation, standard 60 minute appointments and 30 minute check-ins.
* Appointments do not overlap. There can only be one booked appointment at any time.
  * For this one I considered that a patient and a practitioner can have only one appointment at a time,
    so if a practitioner is booked, it cannot have another appointment. Same applies for a patient.
* Appointments start on the hour or half-hour.
* Bookings can only be made for appointments that start and end within the clinic hours.
* Bookings cannot be made within 2 hours of the appointment start time.

##### MVP can be verified through tests
- Provide the patient with a list of available appointment times. Inputs are the appointment type and a date, either today or in the future. The 2 hour booking deadline applies for today’s appointments.
- Allow the patient to book an appointment.
- Provide the practitioner with a list of scheduled appointments for the current day.
