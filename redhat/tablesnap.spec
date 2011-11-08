Name:		tablesnap
Version:	0.2
Release:	1
Summary:	Uses inotify to monitor Cassandra SSTables and upload them to S3
Source:		%{name}-%{version}.tar.gz
Group:		Applications/Databases
License:	BSD
URL:		https://github.com/synack/tablesnap
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release})
BuildArch:	noarch

BuildRequires:	python-setuptools

%description
Uses inotify to monitor Cassandra SSTables and upload them to S3

%prep
%setup -q -n %{name}-%{version}

%build
python setup.py build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}
python setup.py install --skip-build --root %{buildroot}

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files
/usr/bin/tablesnap
/usr/lib/python*
