from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.decorators import parser_classes , permission_classes
from rest_framework.permissions import IsAuthenticated,AllowAny
import json
from .models import flights
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
             

        
        
        
