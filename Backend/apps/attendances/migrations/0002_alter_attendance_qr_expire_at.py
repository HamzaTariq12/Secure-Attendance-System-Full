# Generated by Django 4.2.3 on 2024-03-09 07:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('attendances', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='attendance',
            name='qr_expire_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
