# Generated by Django 3.2.15 on 2022-10-21 04:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('flights', '0006_alter_bookedflights_status'),
    ]

    operations = [
        migrations.AddField(
            model_name='flights',
            name='price',
            field=models.IntegerField(default=5500),
            preserve_default=False,
        ),
    ]
