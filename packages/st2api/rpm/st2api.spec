%define package st2api
%include ../rpmspec/st2pkg_toptags.spec

Summary: St2Api - StackStorm API component
Requires: st2common = %{version}-%{release}

%description
  <insert long description, indented with spaces>

%install
  %default_install
  %pip_install_venv
  %service_install %{name}
  make post_install DESTDIR=%{?buildroot}

%prep
  rm -rf %{buildroot}
  mkdir -p %{buildroot}

%clean
  rm -rf %{buildroot}

%post
  %service_post %{name}

%preun
  %service_preun %{name}

%postun
  %service_postun %{name}

%files
  %{_datadir}/python/%{name}
  %config(noreplace) %{_sysconfdir}/st2/*
%if %{use_systemd}
  %{_unitdir}/%{name}.service
%else
  %{_sysconfdir}/rc.d/init.d/%{name}
%endif
