from django.contrib import admin
from .models import flights ,vouchers,BookedFlights
# Register your models here.

admin.site.register(flights)
admin.site.register(vouchers)
admin.site.register(BookedFlights)