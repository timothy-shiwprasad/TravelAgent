from django.db import models

# Create your models here.
class flights(models.Model):
    flightName = models.CharField(max_length=200,default = "Delta123")
    Departing = models.CharField(max_length=100)
    arriving = models.CharField(max_length=100)
    DateArriving = models.DateField()
    dateleaving = models.DateField()
    TimeArriving = models.TimeField()
    TimeLeaving = models.TimeField()