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


class vouchers(models.Model):
    voucherNumber = models.CharField(max_length=10,default="VA124")
    reduction = models.IntegerField()


class BookedFlights(models.Model):
    UserID = models.IntegerField(null=False)
    flightName = models.CharField(null=False,max_length=30)
    FlightID = models.IntegerField(null=False)
    Class = models.CharField(max_length=30)
    status = models.BooleanField(default=True)
     

