#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 31 14:15:34 2019

@author: brianrice
"""

import pandas as pd
import numpy as np
import calendar

def scrape_rates():
    # Returns stabilized segment rates for each year
    
    # helper function - download file and perform necessary cleaning
    def download_and_clean(url):
        df = pd.read_excel(url, header=2, na_values=["", "NA"])
        df.dropna(axis=0, how='all', inplace=True)
        df.dropna(axis=1, how='all', inplace=True)

        # clean up data and rename columns
        df = df.T
        df.drop('Unnamed: 0', inplace=True)
        df.reset_index(inplace=True)
        df.drop('index', axis=1, inplace=True)

        df.columns = np.arange(-0.5, 100.5, 0.5)
        df.rename(columns={-0.5: 'Year', 0.0: 'Month'}, inplace=True)
        df['Year'].fillna(method='ffill', inplace=True)
        df['Date'] = pd.to_datetime(df['Month'] + ' ' + df['Year']).dt.strftime('%b %Y')
        df['Month'] = df['Month'].apply(lambda x: list(calendar.month_abbr).index(x))
       
        return df

    df = download_and_clean('https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_19_23.xls')

    # add historical data from treasury website
    years_data = [('94', '98'), ('99', '03'), ('04', '08'), ('09', '13'), ('14', '18')]

    for pair in years_data:
        data_old = download_and_clean('https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_{}_{}.xls'.format(pair[0], pair[1]))
        df = df.append(data_old)

    df = df.apply(pd.to_numeric, errors='ignore')
    df = df.loc[df['Year'] <= 2019, ]
    df = df.sort_values(['Year', 'Month'], ascending=[False, False])

    # find segment rates
    df['1st segment - nonstabilized'] = round(df.iloc[:, 2:12].mean(axis=1), 2)
    df['2nd segment - nonstabilized'] = round(df.iloc[:, 12:42].mean(axis=1), 2)
    df['3rd segment - nonstabilized'] = round(df.iloc[:, 42:122].mean(axis=1), 2)

    df['1st segment - stabilized'] = round(df['1st segment - nonstabilized'].rolling(window=24).mean().shift(-23), 2)
    df['2nd segment - stabilized'] = round(df['2nd segment - nonstabilized'].rolling(window=24).mean().shift(-23), 2)
    df['3rd segment - stabilized'] = round(df['3rd segment - nonstabilized'].rolling(window=24).mean().shift(-23), 2)

    # offset by 1 month
    df['1st segment - stabilized'] = df['1st segment - stabilized'].shift(-1)
    df['2nd segment - stabilized'] = df['2nd segment - stabilized'].shift(-1)
    df['3rd segment - stabilized'] = df['3rd segment - stabilized'].shift(-1)

    return df.loc[:, ['Month', 'Year', 'Date', '1st segment - stabilized', '2nd segment - stabilized',
                     '3rd segment - stabilized', '1st segment - nonstabilized',
                     '2nd segment - nonstabilized', '3rd segment - nonstabilized']]

