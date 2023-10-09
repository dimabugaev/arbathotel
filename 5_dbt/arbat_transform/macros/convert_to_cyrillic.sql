{% macro convert_to_cyrillic(input_string) %}
    {% set replacements = {
        'A': 'А',
        'B': 'В',
        'C': 'С',
        'H': 'Н',
        'K': 'К',
        'M': 'М',
        'O': 'О',
        'P': 'Р',
        'E': 'Е',
        'T': 'Т',
        'X': 'Х'
    } -%}
    {% set test_replacements = {
        'А': '*',
        'В': '*',
        'С': '*',
        'Н': '*',
        'К': '*',
        'М': '*',
        'О': '*',
        'Р': '*',
        'Е': '*',
        'Т': '*',
        'Х': '*'
    } -%}
    {% set star_replacements = {
        'A': '*',
        'B': '*',
        'C': '*',
        'H': '*',
        'K': '*',
        'M': '*',
        'O': '*',
        'P': '*',
        'E': '*',
        'T': '*',
        'X': '*'
    } -%}
    {% set converted_string = namespace(result=input_string) %}
    {%- for key, value in replacements.items() -%}
        {% set converted_string.result = "replace(" ~ converted_string.result ~ ", '" ~ key ~ "', '" ~ value ~ "')" %}
    {%-endfor -%}
    {{ converted_string.result }}
{%- endmacro -%}

--A - А, B - В, С - С, H - Н, K - К, M - М, O - О, P - Р, E - Е, T - Т, X - Х