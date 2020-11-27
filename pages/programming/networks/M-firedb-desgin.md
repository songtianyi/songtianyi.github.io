# 防火墙数据库设计

reverted index

`object service` -> doc_id
`{ip}` -> doc_id

FDQL => firedb domain language
grep "1.1.1.1" -A -B -level 2 | match
find "1.1.1.1" -level 2
```json
{
    "address": [
        {"name": "addr1", "subnet": }
    ]
}
```
superset of address "1.1.1.1"
subset of address "1.1.1.1"
equal of address "1.1.1.0/24"

fdql
:
    (superset | subset | equal)+
;

('superset' | 'subset' | 'equal') 'of' ('address' | 'service' | 'policy') "(STRING (SPACE STRING)*"