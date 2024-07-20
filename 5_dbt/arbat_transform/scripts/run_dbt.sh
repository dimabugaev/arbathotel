echo "Running dbt:"
echo ""
dbt deps --project-dir .
echo ""
dbt parse --project-dir .
echo ""
dbt seed --project-dir .
echo ""
if [ "$DBT_TRANSFORM_MODE" = "booking-problems-mart-update" ]; then
    echo "Booking problems marts updating..."
    echo ""
    dbt run -s "+mart_ufms_applications +mart_booking_problem +mart_hotels_escapes +mart_bank_payments +mart_bank_saldo +mart_bank_payments_aq" --project-dir .
elif [ "$DBT_TRANSFORM_MODE" = "full-update" ]; then
    echo "All tables updating..."
    echo ""
    dbt run --project-dir .    
else
    echo "Do nothing..."    
fi
echo ""