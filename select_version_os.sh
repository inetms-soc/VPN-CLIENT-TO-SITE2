while true; do
    read -p "Do you want to install NXLog-CE package y/n? " yn
    case $yn in
        [Yy]* )
        while true; do
            read -p "Which type of OS 1.Ubuntu, 2.CentOS ? " OS
            case $OS in
                [1]* )
                echo "You Select Ubuntu OS"
                while true; do
                    read -p "Which type of OS 1.Ubuntu18 2.Ubuntu20 3.Ubuntu22 ? " VERSION
                    case $VERSION in
                        [1]* )
                        echo "You Select 1.Ubuntu18.04"
                        break;;
                        # if type no = exit
                        [2]* )
                        echo "You Select 2.Ubuntu20.04"
                        break;;
                        [3]* )
                        echo "You Select 3.Ubuntu22.04"
                        break;;
                        * )
                        echo "Please Select [1-3]";;
                    esac
                done
                break;;

                [2]* )
                echo "You Select CentOS OS"
                while true; do
                    read -p "Which type of OS 1.CentOS7 2.CentOS8 3.CentOS9 ? " VERSION
                    case $VERSION in
                        [1]* )
                        echo "You Select 1.CentOS7"
                        break;;
                        # if type no = exit
                        [2]* )
                        echo "You Select 2.CentOS8 "
                        break;;
                        [3]* )
                        echo "You Select 3.CentOS9"
                        break;;
                        * )
                        echo "Please Select [1-3]";;
                    esac
                done
                break;;

                * )
                echo "Please Select [1-2]";;
            esac   

        done
        break;;
        [Nn]* )
        V3=""
        break;;
        * )
        echo "Please answer yes or no.";;
    esac
done
