# What is this all about:

Install Jenkins via Bash. check your required branch as branch specifies linux distros.

# 1. create-path.sh :

Creating jenkins installation path under /opt/SW/Jenkins.

# 2. create-jenkins-user.sh:

Creating the Jenkins user and giving sudo previlages

# 3. install-python-if-not-installed.sh:

Install python as we will require to perform few api operation crumbissuer. This include the creation of an Admin using the password provided by Jenkins (usually, one needs to grab the password from /var/lib/jenkins/secrets/initialAdminPassword and paste it into the browser at http://localhost:8080 to start the setup), the installation of the recommended plugins and the confirmation of the Jenkins’ URL.
This part is a bit tricky since Jenkins uses a CSRF crumb token to, indeed, prevent CSRF attacks (Cross-Site Request Forgery). This token can be grabbed through a suitable API — the crumbIssuer— and it will be bound to the Jenkins Session (Cookie). In each request, the Jenkins Crumb and the Cookie needs to be passed in the Headers to authenticate the request and be able to correctly interact with Jenkins.

# 4. install-jenkins.sh: Download and Install Jenkins

For this part there is a lot of documentation around, first of all the Jenkins download page itself https://www.jenkins.io/download/.

Since Jenkins is written in Java, it needs the JDK to exists in the machine to be able to run, so we first need to download the JDK and then Jenkins.

# 5. copy-adminpassword-create-new-user-and-start-jenkins.sh:

Now that we have downloaded and installed Jenkins, we can proceed to setup the bash script to create a new admin user, download recommended plugins and then confirm the Jenkins URL.

As I mentioned in the introduction, this part can be tricky since we have to deal with the CSRF crumb tokens. In this regard one can read more at the CSRF Protection Explained page.

Let’s break down this code.

url=http://localhost:8080
password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
First We define some variables, the first is the url and the second is the default password that Jenkins should have created for us.

# NEW ADMIN CREDENTIALS URL ENCODED USING PYTHON
username=$(python -c "import urllib;print urllib.quote(raw_input(), safe='')" <<< "user")
new_password=$(python -c "import urllib;print urllib.quote(raw_input(), safe='')" <<< "password")
fullname=$(python -c "import urllib;print urllib.quote(raw_input(), safe='')" <<< "full name")
email=$(python -c "import urllib;print urllib.quote(raw_input(), safe='')" <<< "hello@world.com")
Then we define the variables which store our new credentials. These needs to be URL encoded, and for that we use a simple python script (python2). You can substitute your own credentials after the <<< in each variable.

# GET THE CRUMB AND COOKIE
cookie_jar="$(mktemp)"
full_crumb=$(curl -u "admin:$password" --cookie-jar "$cookie_jar" $url/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
arr_crumb=(${full_crumb//:/ })
only_crumb=$(echo ${arr_crumb[1]})
Here we first create a temporary file and store it in the variable cookie_jar . This will contain the Cookie which will be associated with the Crumb requested. The full_crumb variable is filled with the crumb issued by $url/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\) and this will be of the form:

Jenkins-Crumb: 7fcc05a0b4297fb9556c82f2e602a9f438cd105ad606f91d935ca9513de8b2ff
Since we will also need only the crumb value, we need to split that string and store that value in the variable only_crumb which should contain (for example):

7fcc05a0b4297fb9556c82f2e602a9f438cd105ad606f91d935ca9513de8b2ff
Now that we have all the incredients, we can make the POST request to $url/setupWizard/createAdminUser . We specify some Headers, but the important ones, that I want you to focus your attention to, are the --cookie $cookie_jarand -H "$full_crumb" . We need to pass the cookie with which the crumb has been associated with and the crumb itself. In the --raw-data we pass the information needed by the API to create the admin user we specified.

At this point if we were to open the browser at localhost:8080 , we should be greeted with the Jenkins Login Page:

![image](https://user-images.githubusercontent.com/84220333/204326705-521a56cb-ba9b-4a7d-99d6-b9a9677a3e6b.png)

And not with the ‘Unlock Jenkins’ page:

![image](https://user-images.githubusercontent.com/84220333/204326728-1f7dafb6-4164-4898-9d5f-16b9dfaff711.png)


If we were to log in with the credentials we have provided Jenkins, we would be prompt with the page asking us to install the plugins. But we can do this step via bash script.
