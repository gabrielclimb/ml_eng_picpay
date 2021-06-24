def ale_or_pilsen(text):
    if "ale" in text.lower():
        return "ale"
    elif "lager" in text.lower():
        return "lager"
    else:
        return "who_knows"


def ebc_to_group(ebc_color: float) -> str:
    lovibond = ebc_color / 1.97
    if lovibond <= 7.5:
        return "yellow"
    elif lovibond > 7.5 and lovibond <= 14:
        return "amber"
    elif lovibond > 14 and lovibond <= 25:
        return "brown"
    elif lovibond > 25:
        return "black"


def group_ph(ph_value):
    if ph_value <= 3.8:
        return "(3.198, 3.8]"
    elif ph_value > 3.8 and ph_value <= 4.4:
        return "(3.8, 4.4]"
    elif ph_value > 4.4 and ph_value <= 5:
        return "(4.4, 5.0]"
    elif ph_value > 5:
        return "(5.0, 5.6]"
