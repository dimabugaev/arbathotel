echo "Running dbt:"
echo ""
dbt deps --profiles-dir ./dbt --project-dir ./dbt
echo ""
dbt run -s "+mart_ufms_applications, +mart_booking_problem" --profiles-dir ./dbt --project-dir ./dbt
echo ""