FROM node

# set (create) working directory
WORKDIR /client

# copy package dependencies file
COPY package*.json /client/

# install librairies
RUN npm install

# copy whole project to 
COPY . /client/

EXPOSE 3000

CMD ["npm", "start"]

