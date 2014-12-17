local-dev: build-web-server update-database-config-to-web-local restart-tomcat
	echo 'java ssd local dev done!'


aws-dev: testProject-ssd-server-web-task deploy-aws-dev restart-tomcat
	echo 'java ssd aws dev done!'


################################################################################################################################################################################################


# [Common Modules]: Base
third-party-imports-pom-task:
	@for obj in `find . | sort | grep third-party-imports-pom | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


testProject-super-parent-pom-task: third-party-imports-pom-task
	@for obj in `find . | sort | grep testProject-super-parent | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


testProject-web-module-parent: testProject-super-parent-pom-task
	@for obj in `find . | sort | grep testProject-web-module-parent | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


testProject-ssd-server-plugin-parent: testProject-web-module-parent
	@for obj in `find . | sort | grep testProject-ssd-server-plugin-parent | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


testProject-gateway-plugin-parent: testProject-ssd-server-plugin-parent
	@for obj in `find . | sort | grep testProject-gateway-plugin-parent | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


build-common-modules: testProject-gateway-plugin-parent
	echo 'Common Module Compiled!'


# [Web]: build-common-modules
testProject-ssd-server-modules-pom:
	@for obj in `find . | sort | grep spring-hibernate-core | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done
	@for obj in `find . | sort | grep testProject-ssd-server-modules-pom | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -Drecursive=true -T 4C && cd -;	\
	done


testProject-ssd-server-web-task: testProject-ssd-server-modules-pom
	@for obj in `find . | sort | grep testProject-ssd-server-web | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


# [Gateway]: build-common-modules
testProject-gateway-modules-pom:
	@for obj in `find . | sort | grep spring-hibernate-core | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done
	for obj in `find . | sort | grep testProject-gateway-modules-pom | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -Drecursive=true -T 4C && cd -;	\
	done


testProject-ssd-gateway-web-task: testProject-gateway-modules-pom
	@for obj in `find . | sort | grep testProject-ssd-gateway-web | grep pom.xml`;	\
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"` && echo "\033[44;37m [*]Module Path => $$PWD \033[0m" && mvn clean install -Dmaven.test.skip=true -T 4C && cd -;	\
	done


build-web-server: build-common-modules testProject-ssd-server-web-task
build-gateway-server: build-common-modules testProject-ssd-gateway-web-task
build-both: build-common-modules testProject-ssd-server-web-task testProject-ssd-gateway-web-task


################################################################################################################################################################################################


deploy-aws-dev:
	cp ssd-server/testProject-ssd-server-web/target/testProject-ssd-server-web-*.war /opt/tomcat7/webapps/ROOT.war
	cd /opt/tomcat7/webapps
	rm -rf ROOT
	unzip -o ROOT.war -d ROOT
	rm ROOT.war


update-database-config-to-web-local:
	mkdir tmp/web-server -p
	@cp ssd-server/testProject-ssd-server-web/target/testProject-ssd-server-web-*-SNAPSHOT/WEB-INF/classes/spring-hibernate-config.xml tmp/spring-hibernate-config.xml.tmp -rf
	@sed 's/remote.db.com/localhost/g' tmp/spring-hibernate-config.xml.tmp > tmp/spring-hibernate-config.xml.tmp1
	@sed 's/dev_ssd_data/ssd_data/g' tmp/spring-hibernate-config.xml.tmp1 > tmp/spring-hibernate-config.xml.tmp2
	@sed 's/value="myUser"/value="root"/g' tmp/spring-hibernate-config.xml.tmp2 > tmp/spring-hibernate-config.xml.tmp3
	@sed 's/value="myPassword"/value="rootPassword"/g' tmp/spring-hibernate-config.xml.tmp3 > tmp/spring-hibernate-config.xml.tmp4
	@sed 's/constructor-arg index="1" value=".*"/constructor-arg index="1" value="localhost"/g' tmp/spring-hibernate-config.xml.tmp4 > tmp/spring-hibernate-config.xml.tmp5
	@cp tmp/spring-hibernate-config.xml.tmp5 ssd-server/testProject-ssd-server-web/target/testProject-ssd-server-web-*-SNAPSHOT/WEB-INF/classes/spring-hibernate-config.xml
	@cp -R ssd-server/testProject-ssd-server-web/target/testProject-ssd-server-web*/* tmp/web-server
	@echo "<Context docBase=\"$${PWD}/tmp/web-server\" debug=\"0\" reloadable=\"false\"></Context>" > ./ROOT.xml
	@sudo cp ./ROOT.xml /etc/tomcat7/Catalina/localhost/ROOT.xml -rf


update-database-config-to-gateway-local:
	mkdir tmp/gateway-server -p
	@cp ssd-server/testProject-ssd-gateway-web/target/testProject-ssd-gateway-web-*-SNAPSHOT/WEB-INF/classes/spring-hibernate-config.xml tmp/spring-hibernate-config.xml.tmp -rf
	@sed 's/remote.db.com/localhost/g' tmp/spring-hibernate-config.xml.tmp > tmp/spring-hibernate-config.xml.tmp1
	@sed 's/dev_ssd_data/ssd_data/g' tmp/spring-hibernate-config.xml.tmp1 > tmp/spring-hibernate-config.xml.tmp2
	@sed 's/value="myUser"/value="root"/g' tmp/spring-hibernate-config.xml.tmp2 > tmp/spring-hibernate-config.xml.tmp3
	@sed 's/value="myPassword"/value="rootPassword"/g' tmp/spring-hibernate-config.xml.tmp3 > tmp/spring-hibernate-config.xml.tmp4
	@cp tmp/spring-hibernate-config.xml.tmp4 ssd-server/testProject-ssd-gateway-web/target/testProject-ssd-gateway-web-*-SNAPSHOT/WEB-INF/classes/spring-hibernate-config.xml
	@cp -R ssd-server/testProject-ssd-gateway-web/target/testProject-ssd-gateway-web*/* tmp/gateway-server
	@echo "<Context docBase=\"$${PWD}/tmp/gateway-server\" debug=\"0\" reloadable=\"false\"></Context>" > ./ROOT.xml
	@sudo cp ./ROOT.xml /etc/tomcat7/Catalina/localhost/ROOT.xml -rf


restart-tomcat:
	sudo service tomcat7 restart


clean:
	@for obj in `find . | sort | grep pom.xml`; \
	do \
		cd `echo $$obj | sed -e "s/pom.xml//"`; \
		echo "\033[44;37m [*]Module Path => $$PWD \033[0m"; \
		rm -rf target && cd -; \
	done
	find . -name *.iml | xargs rm -rf
	rm -rf /home/scottlan/.m2/repository/com/testProject
	rm -rf /home/scottlan/.m2/repository/com/benny
	rm -rf ROOT.xml
	rm -rf .idea
	rm -rf ./tmp/*


sync:
	@for obj in `find . | sort | grep pom.xml`; \
	do \
		cd `echo ${PWD}/$$obj | sed -e "s/pom.xml//"`; \
		mkdir -p .svn/tmp/svn-XXXXXX; \
		echo "\033[44;37m [*]Module Path => $$PWD \033[0m"; \
		svn up; \
	done


diff-with-sync:
	@for obj in `find . | sort | grep pom.xml`; \
	do \
		cd `echo ${PWD}/$$obj | sed -e "s/pom.xml//"`; \
		mkdir -p .svn/tmp/svn-XXXXXX; \
		echo "\033[44;37m [*]Module Path => $$PWD \033[0m"; \
		svn diff -r HEAD; \
	done
