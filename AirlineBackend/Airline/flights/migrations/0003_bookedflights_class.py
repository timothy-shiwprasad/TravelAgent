# Generated by Django 3.2.15 on 2022-10-07 18:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('flights', '0002_bookedflights_vouchers'),
    ]

    operations = [
        migrations.AddField(
            model_name='bookedflights',
            name='Class',
            field=models.CharField(default='first', max_length=30),
            preserve_default=False,
        ),
    ]
