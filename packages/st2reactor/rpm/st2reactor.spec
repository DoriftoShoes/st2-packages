%define package st2reactor
%include ../rpmspec/st2pkg_toptags.spec

Summary: St2Reactor - StackStorm sensors component
Requires: st2common = %{version}-%{release}

%description
  <insert long description, indented with spaces>

%install
  %default_install
  %pip_install_venv
  %service_install st2rulesengine st2sensorcontainer
  make post_install DESTDIR=%{?buildroot}

%prep
  rm -rf %{buildroot}
  mkdir -p %{buildroot}

%clean
  rm -rf %{buildroot}

%post
  %service_post st2rulesengine st2sensorcontainer

%preun
  %service_preun st2rulesengine st2sensorcontainer

%postun
  %service_postun st2rulesengine st2sensorcontainer

%files
  %{_bindir}/*
  %{_datadir}/python/%{name}
  %config(noreplace) %{_sysconfdir}/st2/*
%if %{use_systemd}
  %{_unitdir}/st2rulesengine.service
  %{_unitdir}/st2sensorcontainer.service
%else
  %{_sysconfdir}/rc.d/init.d/st2rulesengine
  %{_sysconfdir}/rc.d/init.d/st2sensorcontainer
%endif
