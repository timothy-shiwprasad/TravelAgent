from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.decorators import parser_classes , permission_classes
from rest_framework.permissions import IsAuthenticated,AllowAny
import json
from .models import flights , vouchers ,BookedFlights
from django.http import JsonResponse
# Create your views here.

@api_view(['GET'])
@permission_classes([AllowAny])
def getFlight(request,format = None):
    if request.method == "GET":
        data = request.data
        matchedFlights = flights.objects.filter(Departing=data["origin"],arriving=data["destination"],dateleaving=data["date"])
        print(matchedFlights)
        jsonresponse = {}
        jsonresponse["flights"] = []
        for flight in matchedFlights:
            jsonFlight = {
                "ID": flight.id,
                "Flight" : flight.flightName,
                "Departing" : flight.Departing,
                "Destination" : flight.arriving,
                "DateArriving" : flight.DateArriving,
                "DateDeparting" : flight.dateleaving,
                "TimeArriving" : flight.TimeArriving,
                "TimeLeaving" : flight.TimeLeaving
            }

            jsonresponse["flights"].append(jsonFlight)

        return JsonResponse(jsonresponse)
             
       
@api_view(["GET"])
@permission_classes([AllowAny])
def checkVoucher(request,format=None):
    if request.method == "GET":
        data = request.data
        try:
            voucherInfo = vouchers.objects.get(voucherNumber=data["voucherNumber"])

        except:

            response = {"valid":False , "voucherNumber" : data["voucherNumber"]}
        
        else:
            response = {"valid": True,"voucherNumber":voucherInfo.voucherNumber , "reduction":voucherInfo.reduction}


        return JsonResponse(response)



@api_view(["POST"])
@permission_classes([AllowAny])
def bookFlight(request,format=None):
    if request.method == "POST":
            data =request.data
            newFlight = BookedFlights()
            newFlight.UserID = data["ID"]
            newFlight.flightName = data["name"]
            newFlight.FlightID =data["FlightID"]
            newFlight.Class = data["class"]
            newFlight.save()


    return JsonResponse({"saved": True})


@api_view(["GET"])
@permission_classes([AllowAny])
def usersFlight(request,format=None):
     if request.method == "GET":
        data = request.data
        userFlights = BookedFlights.objects.filter(UserID=data["UserID"])
    
        jsonresponse = {}
        jsonresponse["flights"] = []
        Sflight = {}
        if(len(userFlights) > 0):
            
            for singleflights in userFlights:
                fly = flights.objects.get(id=singleflights.FlightID)
                Sflight["flightName"] = fly.flightName
                Sflight["origin"] = fly.Departing
                Sflight["destination"] = fly.arriving
                Sflight["DateArriving"] = fly.DateArriving
                Sflight["DateLeaving"] = fly.dateleaving
                Sflight["TimeArriving"] = fly.TimeArriving
                Sflight["TimeLeaving"] = fly.TimeLeaving
                jsonresponse["flights"].append(Sflight)
                Sflight = {}

        else:
            jsonresponse = {"flights" : None}
        

        return JsonResponse(jsonresponse)