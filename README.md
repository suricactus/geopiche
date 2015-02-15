# geopiche

Geopiche е проект, имащ за цел да събере всички нецензурни и вулгарни имена на селищата по света.

### Инсталация
В ui е всичко необхосимо за работа на приложението.

Ако има нужда да се пусне анализиращия скрипт отново, то от руута на проекта:

    perl scripts/analyze.pl > data.json
    
    
### Настройка
При нужда от допълнителни вулгаризми за търсене, трябва да се добавят в `./data/terms.csv`. 

### Източници
- **worldcitiespop.txt** - https://code.google.com/p/worlddatapro/

### Използвани технологии и езици
- **javascript** - jQuery, LeafMap
- **Perl**

### Лиценз
Само не го затваряйте. И да, отворете си настоящия код :) GPL 2.0
