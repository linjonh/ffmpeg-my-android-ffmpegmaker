echo $(cd $(dirname $0) && pwd)
# $#	传递到脚本的参数个数
# $*	以一个单字符串显示所有向脚本传递的参数。
#       如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
# $$	脚本运行的当前进程ID号
# $!	后台运行的最后一个进程的ID号
# $@	与$*相同，但是使用时加引号，并在引号中返回每个参数。
#       如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
# $-	显示Shell使用的当前选项，与set命令功能相同。
# $?	显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。
echo "\$#="$#
echo "\$*="$*
echo "\$@="$@
echo "\$-="$-
echo "\$!="$!
echo "\$?="$?
echo "\$$="$$

ARRAY=(hello 1f 22 3h 4 5 hello shell test sh 。)
#读取数组所有元素个数
echo ${#ARRAY[*]}
echo ${#ARRAY[@]}
#读取数组所有元素
echo ${ARRAY[*]}
echo ${ARRAY[@]}
#读取数组所有键
echo ${!ARRAY[*]}
echo ${!ARRAY[@]}
#声明键值对数组
declare -A ar=(["ok"]="tingao")
ar["hello"]=nihao
echo ${!ar[*]}
echo ${ar[*]}
echo ${ar[ok]}
echo ${ar[hello]}

#函数
function fun() {
    echo test function
    echo 参数个数=$#
    echo 参数所有字符串=$*
    echo 参数所有字符串=$@
    echo $0
    echo $1
    echo \$2=$2
    echo \$3=$3

    echo "-- \$* 演示 ---"
    for i in "$*"; do
        echo $i
    done

    echo "-- \$@ 演示 ---"
    for i in "$@"; do
        echo $i
    done
}
#函数调用，和函数参数
fun test func hello

#for循环
echo test for loop
for i in ${ARRAY[*]}; do
    echo i=$i
done
#while 循环， 计算表达式需要方括号括起来且要有空格间隔
int=0
while [ $int -lt 10 ]; do
    let int++
    echo $int
done
#until 循环执行一系列命令直至条件为 true 时停止。
int=0
until [ ! $int -lt 10 ]
do
 let int++
    echo $int
done

# 无限循环
# 无限循环语法格式：

# while :
# do
#   echo  command
# done

# 或者

# while true
# do
#    echo command
# done

# 或者

# for (( ; ; ))

#case
int=(0 1 2 3)
for i in ${int[*]}
do
    case $i in
        0) echo case 0;;
        1) echo case 1;;
        *) echo else echo $i ;;
    esac
done

#break continue

echo "\$OSTYPE=$OSTYPE"

