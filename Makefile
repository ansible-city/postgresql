
BRANCH?=$(shell git rev-parse --abbrev-ref HEAD)

all: test clean

watch: test_deps
	while sleep 1; do \
		find defaults/ handlers/ meta/ tasks/ templates/ tests/test.yml \
		tests/vagrant/Vagrantfile \
		| entr -d make lint vagrant_up; \
	done

test: test_deps vagrant_up

integration_test: clean integration_test_deps vagrant_up clean

test_deps:
	rm -rf tests/ansible-city.*
	ln -s .. tests/ansible-city.postgresql

integration_test_deps:
	sed -i.bak \
		-E 's/(.*)version: (.*)/\1version: origin\/$(BRANCH)/' \
		tests/vagrant/integration_requirements.yml
	rm -rf tests/vagrant/ansible-city.*
	ansible-galaxy install -p tests/vagrant -r tests/vagrant/integration_requirements.yml
	mv tests/vagrant/integration_requirements.yml.bak tests/vagrant/integration_requirements.yml

lint:
	! find handlers/ meta/ tasks/ -name "*.yml" -type f | xargs grep -E "({{[^ ]|[^ ]}})"

vagrant_up:
	cd tests/vagrant && vagrant up --no-provision
	cd tests/vagrant && vagrant provision

vagrant_ssh:
	cd tests/vagrant && vagrant up --no-provision
	cd tests/vagrant && vagrant ssh

clean:
	rm -rf tests/ansible-city.*
	cd tests/vagrant && vagrant destroy
