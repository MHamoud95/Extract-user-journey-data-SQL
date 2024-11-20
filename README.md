# Extracting User Journey Data with SQL

## Overview

This project, **Extracting User Journey Data with SQL**, is focused on extracting insights from customer journey data by querying a MySQL database. The database includes details on visitor interactions, user purchases, and their journeys through the company's front pages. The data has been anonymized to exclude any personally identifiable information (PII).

The source data and project come from [365 Data Science](https://learn.365datascience.com/).

## Project Structure

The project consists of the following files:

- **User_Journey_Database.sql** - SQL script to generate the database and tables for this project.
- **URL_Aliases.xlsx** - A reference file containing URL aliases for pages in the dataset.
- **README.md** - Documentation file for the project.

### Database Tables

The database used for this project contains three primary tables:

#### 1. **front_interactions**
This table logs all visitor activities on the company’s front page, including page views, clicks, and other interactions.

**Columns:**
- `visitor_id` (int) – Unique ID for each visitor.
- `session_id` (int) – The session number during which the interaction occurred.
- `event_source_url` (string) – The URL of the page where the interaction took place.
- `event_destination_url` (string) – The URL of the page where the interaction was completed (same as the source URL for actions like scrolling or clicking a form).
- `event_date` (datetime) – The timestamp of the interaction.
- `event_name` (string) – The internal name of the event.

#### 2. **student_purchases**
This table tracks user purchases and the type of product they bought. It records all purchases, including recurring payments for the same subscription.

**Columns:**
- `user_id` (int) – Unique ID for the user.
- `purchase_id` (int) – Unique ID for the purchase.
- `purchase_type` (int) – Type of subscription purchased (0=monthly, 1=quarterly, 2=annual).
- `purchase_price` (decimal) – The price paid for the purchase.
- `date_purchased` (datetime) – The timestamp when the purchase was made.

#### 3. **front_visitors**
This table links visitors with their corresponding users (if they created an account). It is used to relate data between the `front_interactions` and `student_purchases` tables.

**Columns:**
- `visitor_id` (int) – The ID of the visitor.
- `user_id` (int) – The ID of the user corresponding to the visitor (many NULL values for visitors who have not created an account).

## Getting Started

### Step 1: Set Up MySQL

1. Open your local MySQL connection.
2. Open the **User_Journey_Database.sql** file in MySQL Workbench or any MySQL client.
3. Run all commands in the script to create the schema and relevant tables. This process may take a few minutes (1-10 minutes), so please be patient and do not restart MySQL during this time.

### Step 2: Data Source

- All data used in this project is anonymized to exclude any personal information.
- The dataset is provided by **365 Data Science**.

### Step 3: Data Structure

The database consists of three tables:
1. `front_interactions`
2. `student_purchases`
3. `front_visitors`

These tables contain data relevant to the customer journey, from page visits to purchases.

### Step 4: Using the URL_Aliases File

The **URL_Aliases.xlsx** file contains a reference list with URLs and suggested aliases. It can help in interpreting the various URLs within the dataset, which may be unfamiliar.

## Notes

- **Test Users:** Some test user records may be present in the data. These should be excluded in any analysis or queries.
- **Data Familiarization:** Before jumping into querying, take the time to explore and familiarize yourself with the database structure.
