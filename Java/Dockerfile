FROM openjdk:11
COPY . /project
WORKDIR /project
RUN ./gradlew bootJar
RUN mv ./build/libs/Proiect_SGBD.jar /
WORKDIR /
RUN rm -r /project
EXPOSE 22
EXPOSE 8080
CMD ["java", "-jar", "Proiect_SGBD.jar"]
