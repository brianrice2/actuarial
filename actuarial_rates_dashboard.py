#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 14:47:55 2019

@author: brianrice
"""

import dash
import dash_table as dt
import dash_html_components as html
import dash_core_components as dcc
import pandas as pd

from dash.dependencies import Input, Output
from scrape_actuarial_rates import scrape_rates

df = scrape_rates()
cols = ['Date', 'Month', 'Year', '1st segment - stabilized',
        '2nd segment - stabilized', '3rd segment - stabilized',
        '1st segment - nonstabilized', '2nd segment - nonstabilized',
        '3rd segment - nonstabilized']
df = df[cols]


app = dash.Dash(__name__)

app.layout = html.Div(
    [
#        dcc.DropDown(
#            id='table-dropdown-month',
#            options=[{"label": i, "value": i} for i in df['Month']]
#        ),
#        
#        dcc.DropDown(
#            id='table-dropdown-year',
#            options=[{"label": i, "value": i} for i in df['Year']]
#        ),
        
        dt.DataTable(
            id='table',
            filter_action="native",
        
            style_data_conditional=[
                {
                    'if': {'row_index': 'odd'},
                    'backgroundColor': '#eef8ff'
                }
            ],
            style_header={
                'fontWeight': 'bold',
                'textAlign': 'center',
                'backgroundColor': '#eef8ff'
            },
            columns=[
                {"name": ["", "Date"], "id": "Date"},
                {"name": ["", "Year"], "id": "Year"},
                {"name": ["", "Month"], "id": "Month"},
                {"name": ["Stabilized", "1st segment"], "id": "1st segment - stabilized"},
                {"name": ["Stabilized", "2nd segment"], "id": "2nd segment - stabilized"},
                {"name": ["Stabilized", "3rd segment"], "id": "3rd segment - stabilized"},
                {"name": ["Nonstabilized", "1st segment"], "id": "1st segment - nonstabilized"},
                {"name": ["Nonstabilized", "2nd segment"], "id": "2nd segment - nonstabilized"},
                {"name": ["Nonstabilized", "3rd segment"], "id": "3rd segment - nonstabilized"},
            ],
            style_cell={
                    'padding': '15px',
                    'width': 'auto',
                    'textAlign': 'right'
            },
            merge_duplicate_headers=True,
            data=df.to_dict('records')
        ),
    html.Div(id='table-container')
    ]
)

#@app.callback(Output('table-element', 'rows'), [Input('table-dropdown-month', 'value')])
#def update_rows_month(value):
#    return df[df['Month'] == value].to_dict('records')
#
#@app.callback(Output('table-element', 'rows'), [Input('table-dropdown-year', 'value')])
#def update_rows_year(value):
#    return df[df['Year'] == value].to_dict('records')


if __name__ == '__main__':
    app.run_server(debug=True)
    