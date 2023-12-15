echo "Running dbt:"
echo ""
dbt deps --profiles-dir ./dbt --project-dir ./dbt
echo ""
if [ "$DBT_TRANSFORM_MODE" == "booking-problems-mart-update" ]; then
    echo "Booking problems marts updating..."
    echo ""
    dbt run -s "+mart_ufms_applications, +mart_booking_problem" --profiles-dir ./dbt --project-dir ./dbt
elif [ "$DBT_TRANSFORM_MODE" == "full-update" ]; then
    echo "All tables updating..."
    echo ""
    dbt run --profiles-dir ./dbt --project-dir ./dbt    
else
    echo "Do nothing..."    
fi
echo ""