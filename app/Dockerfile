FROM node

# set working directory
WORKDIR /app

# copy package dependencies file
COPY package*.json /app/

# install librairies
RUN npm install

# copy whole project to 
COPY . /app/

EXPOSE 4000

CMD ["npm", "start"] 