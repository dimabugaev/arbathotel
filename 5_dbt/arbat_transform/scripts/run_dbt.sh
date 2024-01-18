echo "Running dbt:"
echo ""
dbt deps --project-dir .
echo ""
dbt parse --project-dir .
echo ""
if [ "$DBT_TRANSFORM_MODE" = "booking-problems-mart-update" ]; then
    echo "Booking problems marts updating..."
    echo ""
    dbt run -s "+mart_ufms_applications +mart_booking_problem +mart_hotels_escapes" --project-dir .
elif [ "$DBT_TRANSFORM_MODE" = "full-update" ]; then
    echo "All tables updating..."
    echo ""
    dbt run --project-dir .    
else
    echo "Do nothing..."    
fi
echo ""