# Summary
This repo contains a fully reproducible example of the FELDM task. Note that this was only tested in a linux environment (Ubuntu 24.04.1 LTS) and requires that task is [installed](https://taskfile.dev/installation/).

To set up the environment, database and dbt, navigate to the results folder and execute the following commands:
* `task install-linux-dependencies-debian` This installs all required dependencies.
* `task migrate-and-run` This sets up a postgres database in a docker container and creates the tables in the database using [sqllite migrator](https://pgloader.readthedocs.io/en/latest/ref/sqlite.html). Note that for some reason only 1 row gets loaded into the employees table. This was later manually loaded into the database.
* 'task set-up-dbt`. This sets the path to the profiles.yml and installs the package dependencies

By navigating to the folder results/feldm/dbt, any dbt command can be executed to explore the dbt project. For ease of use, two additional tasks can also be executed instead (from the results folder):
* `task run-all-dbt` This runs and tests all models in the dbt project.
* `task generate-dbt-docs` This generates and serves the dbt documentation.


# DBT Design decisions
## Database
The data was provided in a sqlite extract. However, sqlite is not an official adapter of dbt and at the moment only supports up until dbt-core 1.5. Therefore, the decision was made to use postgresql so that the latest version of dbt-core can be used.

## Project configuration and profiles.yml
By default dbt has a `generate_schema_name` macro that prefixes the default schema defined in the profiles.yml to the custom_schema name defined for folders in the dbt-project.yml (or in other places in the project). Often, this is not desired behavior in the prod environment, where the custom_schema_name usually is the desired schema, where the model should be materialized. Hence, the macro is amended and added to the macros folder, and the target defined in the profiles.yml is set to prod so the models get materialized to the schemas defined in the dbt-project.yml.

## Packages
Several packages have been added to the dbt project:
* dbt_utils: This package contains many different utility functions, but in particular generate_surrogate_key and the unique_combination_of_columns test were used.
* dbt_expectations: This package was used to create a simple date dimension and test for correct datatypes.
* codegen: This package was used to quickly generate the staging tables. This package contains many useful macros for generating sources and models.

For formatting [sqlfmt](https://sqlfmt.com/) was chosen. This is added as a dependency in the python environment and does not require any additional setup.

## Documentation
For documentation a separate folder was added, docs. By using docs-paths in the dbt-project.yml, all markdown files used in the dbt project can be saved under that folder and then referenced everywhere in the dbt project. Aside from descriptions on the different models made, a markdown with column description was added, so that column descriptions can be reused when they appear across multiple models.

## Out-of-scope
There are many more elements that could have been added to the dbt project that due to time constraints weren't implemented:
* unit_tests: No immediate unit tests came to mind when evaluating the data. Possibilities could have been to check the strings in the different varchar columns for special characters. At this point, the special characters were not removed, but this can sometimes be a requirement from the business.
* More datatests: Unique and not_null tests are added to every model, wherever appropriate relationships are added and as an example datatype tests from dbt_expectations are added. However, there are many more options to test robustness of models. For example, for more data quality testing the package [Elementary](https://docs.elementary-data.com/introduction) can be used.
* Grants: Access grants still need to be added. This should be based on an access control policy.
* PII: It was discovered that multiple models had PII-sensitive data in it. This was left out and noted that this should be masked if needed downstream.