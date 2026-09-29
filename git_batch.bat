@echo off
cd C:\GITHUB_Master\Moment-Distribution-Method

echo Dodavanje izmjena u staging area...
git add .

echo Commitanje izmjena...
git commit -m "Update Moment-Distribution-Method"

echo Slanje izmjena na GitHub...
git push origin main

echo Povlacenje najnovijih izmjena iz GitHub repozitorija...
git pull origin main

echo Gotovo!
pause
