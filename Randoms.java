/*
 * Randoms.java
 * Jennifer Meneghin
 * 06/02/2009
 * Updated 09/02/2009
 */
import java.util.*;

public class Randoms {
    public static void main(String[] args) {
	double maxValue = 0.0;
	int numsToChoose = 0;
	boolean withReplacement = false;

	if (args.length < 2) {
	    usage();
	    System.exit(1);
	}
	try {
	    maxValue = Double.parseDouble(args[0]);
	    numsToChoose = Integer.parseInt(args[1]);
	    if (args.length > 2) {
		if (args[2].equals("wr")) {
		    withReplacement = true;
		}
	    }
	}
	catch (NumberFormatException e) {
	    usage();
	    System.exit(1);
	}
	if ( numsToChoose >= maxValue ) {
	    usage();
	    System.exit(1);
	}
	Random random = new Random();
	ArrayList nums = new ArrayList();
	while ( nums.size() < numsToChoose ) {
	    Double next = new Double(Math.ceil(random.nextDouble()*maxValue));
	    if (!nums.contains(next) || withReplacement) {
		nums.add(next);
	    }
	}
	for (int i = 0; i < nums.size(); i++ ) {
	    System.out.println(((Double)nums.get(i)).intValue());
	}
    }
    
    static public void usage() {
	System.out.println("Usage: java Randoms X Y optional:wr");
	System.out.println("This program randomly selects Y numbers from the range[1,X], without replacement, with a uniform distribution.");
	System.out.println("If \"wr\" is included at the end of the line, it will choose WITH replacement instead.");
	System.out.println("Jennifer Meneghin 09/02/2009");
   }
}

