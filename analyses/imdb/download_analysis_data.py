import requests
import sys
import gzip
from io import BytesIO
import pandas as pd
import wikipedia as wp

id_outfile = sys.argv[1] if len(sys.argv) > 1 else 'hollywood-2011-ids.txt'
nominee_outfile = sys.argv[2] if len(sys.argv) > 2 else 'academy_award_nominees.csv'


# ID - Name Mapping 

url = 'http://data.law.di.unimi.it/webdata/hollywood-2011/hollywood-2011.ids.gz'
r = requests.get(url, allow_redirects=True)

with gzip.open(BytesIO(r.content)) as f:
    # add ids as column to have a direct mapping
    id_mapping = pd.read_csv(f, sep='\t', header=None)
    id_mapping.to_csv(id_outfile)


# Wikipedia Academy Award Nominees list

html = wp.page("List_of_actors_with_Academy_Award_nominations").html().encode("UTF-8")
try: 
    nominee_list = pd.read_html(html)[1]  # Try 2nd table first as most pages contain contents table first
except IndexError:
    nominee_list = pd.read_html(html)[0]
nominee_list.to_csv(nominee_outfile)
