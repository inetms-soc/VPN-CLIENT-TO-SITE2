while true; do
    read -p "Do you want to install NXLog-CE package y/n? " yn
    case $yn in
        [Yy]* )
        while true; do
            read -p "Which type of OS 1.Ubuntu 18.04, 2.Ubuntu 20.04, 3.CentOS 7, 4.CentOS 8 ? " OS
            case $OS in
                [1]* )
                echo "You Select Ubuntu 18.04 OS"
                echo "Installing NXLog-CE Package"
                apt install nxlog-ce -y
                echo "NXLog-CE was installed"
                cp -a nxlog_server.conf /etc/nxlog/nxlog.conf
                echo -e "Copy NXLog Configuration Done.....!\n"
                V3="NXLog-CE Package"
                break;;
                [2]* )
                echo "You Select Ubuntu 20.04 OS"
                echo "Installing NXLog-CE Package"
                apt install nxlog-ce -y
                echo "NXLog-CE was installed"
                cp -a nxlog_server.conf /etc/nxlog/nxlog.conf
                echo -e "Copy NXLog Configuration Done.....!\n"
                V3="NXLog-CE Package"
                break;;
                [3]* )
                echo "You Select CentOS 7 OS"
                echo "Installing NXLog-CE Package"
                yum install nxlog-ce -y
                echo "NXLog-CE was installed"
                cp -a nxlog_server.conf /etc/nxlog/nxlog.conf
                echo -e "Copy NXLog Configuration Done.....!\n"
                V3="NXLog-CE Package"
                break;;
                [4]* )
                echo "You Select CentOS 8 OS"
                echo "Installing NXLog-CE Package"
                yum install nxlog-ce -y
                echo "NXLog-CE was installed"
                cp -a nxlog_server.conf /etc/nxlog/nxlog.conf
                echo -e "Copy NXLog Configuration Done.....!\n"
                V3="NXLog-CE Package"
                break;;
                * )
                echo "Please answer 1, 2, 3, or 4";;
            esac
        done
        break;;
        # if type no = exit
        [Nn]* )
        V3=""
        break;;
        * )
        echo "Please answer
