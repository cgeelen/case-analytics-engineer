# Summary
This repo contains a fully reproducible example of the FELDM task. Note that this was only tested in a linux environment (Ubuntu 24.04.1 LTS) and requires that Taskfile is [installed](https://taskfile.dev/installation/). 

- [Summary](#summary)
  - [What is Taskfile and how can I use it?](#what-is-taskfile-and-how-can-i-use-it)
  - [Targets](#targets)
- [Stack](#stack)
- [DBT Design decisions](#dbt-design-decisions)
  - [Database](#database)
  - [Project configuration and profiles.yml](#project-configuration-and-profilesyml)
  - [Packages](#packages)
  - [Documentation](#documentation)
- [WIP](#wip)
  - [DBT](#dbt)
  - [Reproducibility](#reproducibility)


## What is Taskfile and how can I use it?
Taskfile is a YAML-based alternative to Make files and has the added benefit that it is more readeable and has some additional comfort-features, when compared to Makefiles.

## Targets
To set up the environment, database and dbt, navigate to the results folder and execute the following commands:
* `task install-linux-dependencies-debian` This installs all required dependencies.
* `task migrate-and-run` This sets up a postgres database in a docker container and creates the tables in the database using a helper container that runs [pg loader](https://pgloader.readthedocs.io/en/latest/ref/sqlite.html). Note that for some reason only 1 row gets loaded into the employees table. This was later manually loaded into the database.
* `task set-up-dbt`. This sets the path to the profiles.yml and installs the package dependencies

By navigating to the folder results/feldm/dbt, any dbt command can be executed to explore the dbt project. For ease of use, two additional tasks can also be executed instead (from the results folder):
* `task run-all-dbt` This runs and tests all models in the dbt project.
* `task generate-dbt-docs` This generates and serves the dbt documentation.


# Stack
The stack of this project is:
* Task, as a workflow tool to install and configure the operating system
* Docker, to reproduce containerized runtimes, like that of the Postgres Database.
* PG-Loader, a Postrgres tool that runs natively on linux and is able to migrate between SQL sources, including SQLite.  
* Pyenv, to install a Python environment
* Poetry, to manage and lock Python dependencies and install a virtual environment for the dbt runtime
* dbt, specifically `dbt-core` and `dbt-postgres` that provides this project with the core utilities and a means to connect to the Postgres database.

Note that this stack is not designed for production use-cases. Only the Python dependencies are locked with the use of Poetry. The versions of the docker images as well as the system dependencies that are installed, assume the latest release, potentially causing instability. 

# DBT Design decisions
## Database
The data was provided in a SQLite extract and CSVs. CSVs are problematique as the fundamentally do not have data-typing. To interface with SQLite directly has also proven to be challenging. SQLite does not have a fully fledged SQL-engine and dbt-labs does not officialy support a SQLite connector. The [recommended approac](https://docs.getdbt.com/docs/core/connect-data-platform/sqlite-setup) as denoted by dbt-labs is to use the community connector from [codeforkjeff](https://github.com/codeforkjeff/dbt-sqlite), which at the moment only supports up until dbt-core 1.5. Therefore, the decision was made to use postgresql so that the latest version of dbt-core can be used.

## Project configuration and profiles.yml
By default dbt has a `generate_schema_name` macro that prefixes the default schema defined in the profiles.yml to the custom_schema name defined for folders in the dbt-project.yml (or in other places in the project). Often, this is not desired behavior in the prod environment, where the custom_schema_name usually is the desired schema, where the model should be materialized. Hence, the macro is amended and added to the macros folder, and the target defined in the profiles.yml is set to prod so the models get materialized to the schemas defined in the dbt-project.yml.

## Packages
Several packages have been added to the dbt project:
* [dbt_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/): This package contains many different utility functions, but in particular generate_surrogate_key and the unique_combination_of_columns test were used.
* [dbt_expectations](https://hub.getdbt.com/calogica/dbt_expectations/latest/): This package was used to create a simple date dimension and test for correct datatypes.
* [codegen](https://hub.getdbt.com/dbt-labs/codegen/latest/): This package was used to quickly generate the staging tables. This package contains many useful macros for generating sources and models.

For formatting [sqlfmt](https://sqlfmt.com/) was chosen. This is added as a dependency in the python environment and does not require any additional setup.

## Documentation
For dbt documentation a separate folder, called [docs](./dbt/feldm/docs/) was added. By using docs-paths in the [dbt-project.yml](./dbt/feldm/dbt_project.yml), all markdown files used in the dbt project can be saved in that folder and referenced everywhere in the dbt project. Aside from descriptions on the different models made, a markdown with [column descriptions](./dbt/feldm/docs/column_definitions.md) was added, so that column descriptions can be reused when they appear across multiple models.

# WIP
The current state of the project is narrowly scoped around a working and reproducible example of a full dbt implementation. Many improvement can be made in regards to the quality of the reproducibility and the documentation and tests within dbt.

## DBT
There are many more elements that could have been added to the dbt project that due to time constraints weren't implemented:
* [unit_tests](https://docs.getdbt.com/docs/build/unit-tests): No immediate unit tests came to mind when evaluating the data. Possibilities could have been to check the strings in the different varchar columns for special characters. Sspecial characters were not removed, but this can sometimes be a requirement from the business.
* More datatests: Unique and not_null tests are added to every model, wherever appropriate relationship tests are added and as an example datatype tests from dbt_expectations are added. However, there are many more options to test robustness of models. For example, for more data quality testing the package [Elementary](https://docs.elementary-data.com/introduction) can be used.
* [Grants](https://docs.getdbt.com/reference/resource-configs/grants): Access grants still need to be added. This should be based on an access control policy.
* PII: It was discovered that multiple models had PII-sensitive data in it. This was left out and noted that this should be masked if needed downstream.
* To make a complete star-schema, a dim_products, dim_employees, and dim_shippers table should still be added.
* The fct_sales table was the only model made incremental. The dm_customer_cohort could also be made incremental.

## Reproducibility
* [ ] The Stack has not been tested on Windows
* [ ] The Stack has not been tested on MacOS
* [ ] The versions of containers are not yet locked
* [ ] Build-tests are missing
* [ ] The employees table 