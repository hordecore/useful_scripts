#!/bin/bash

debug=0
if [ "$1" = 'debug' ]; then
	debug=1
	shift
fi

cd /devel/master_ro

branch=$(</devel/branch)
. /devel/bin/versions.sh

echo -e "\nVersion $version $build" > /tmp/changelog.final.tmp
for repo in /devel/src/* /devel/${branch}_ro; do 
	[ -d "$repo/.git" ] || continue; cd $repo && git checkout $branch || { wall PANIC; break; }
	reponame=${repo##*/}
	# from="$(cat ChangeLog.master | grep -m1 $reponame | awk '{print $4}' | tr -d ':')"
	# git log --pretty=medium --date=short --no-notes  --abbrev-commit "$from..HEAD")
	# declare fromhead
	from=""
	from="$(cat /devel/ChangeLog.$branch | grep -m1 $reponame | awk '{print $4}' | tr -d ':')"
	[ "$from" != "" ] && from="$from..HEAD"
	echo $reponame $from >&2 
	# sleep 1
	rm -f /tmp/$reponame.first*
	unset isfirst
	git log --pretty=medium --date=short --no-notes  --abbrev-commit $from |\
		grep -v '...skipping...'\
		| ( while read hh h t; do 
	[ "$hh" != 'commit' ] && continue; 
	read ah anm; [ "$ah" != 'Author:' ] && continue;
	read dh d; [ "$dh" != 'Date:' ] && continue;
	read ; read s;  
	echo -en "${d} $reponame ${anm// /|}";
	echo -e "\t* $h: $s";
	if [ "$isfirst" = "" ]; then
		echo $reponame isfirst null >&2			
		echo $h >/tmp/$reponame.first
		echo $d >/tmp/$reponame.first.d
		isfirst=1
	fi
done
)
echo isfirst: $isfirst >&2
sleep 1
done > /tmp/changelog.tmp

for repo in /devel/src/* /devel/${branch}_ro; do 
	[ -d "$repo/.git" ] || continue
	r=${repo##*/}
	h=$(</tmp/$r.first)
	d=$(</tmp/$r.first.d)
	a='ChangeLog <changelog@carbonsoft.ru>'
	msg="Update"
	[ "$first" = "" ] && echo -e "\n$d ${a}";
	echo -e "\t* Change $r ${h}: $msg" ;
	first=1
done >>/tmp/changelog.final.tmp

cat /tmp/changelog.tmp| grep -v 'Your branch is' | sort  -k1,1r -k3,3 | grep -v [+]0[56]00 | while read d r a tmp h msg; do [ "$prevda" != "$d$a" ] && echo -e "\n$d ${a//|/ }"; echo -e "\t* Change $r $h $msg" ; prevda=$d$a; done >> /tmp/changelog.final.tmp

cat /devel/ChangeLog.$branch >> /tmp/changelog.final.tmp

cp /devel/ChangeLog.$branch /devel/var/bk/ChangeLog.${branch}.${version}_${build}
mv /tmp/changelog.final.tmp /devel/ChangeLog.$branch
while IFS= read line; do
	echo "$line" | iconv -f koi8 -t utf8
done < /devel/ChangeLog.$branch > /devel/ChangeLog.$branch.utf8
# from="$(cat ChangeLog.master | grep -m1 $reponame | awk '{print $4}' | tr -d ':')"

echo 'Check it out!'
grep Version /devel/ChangeLog.$branch | head -10
