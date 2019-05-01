FROM auroradog/shinybasic:part2

RUN R -e "install.packages(c('stats19', 'shinycssloaders', 'plotly', 'leaflet','geojsonsf', 'aws.signature', 'aws.s3'), repos='https://cran.rstudio.com/')"

RUN rm -rf /srv/shiny-server/*

COPY shinyapps /srv/shiny-server/

COPY shiny /home/shiny


RUN chown -R shiny:shiny /home/shiny
USER shiny  
EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]



