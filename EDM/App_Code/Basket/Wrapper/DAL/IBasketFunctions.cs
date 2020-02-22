using System.Data;
using System.Collections;

/// <summary>
/// Summary description for IOBFunctions
/// </summary>
namespace HIT.OB.STD.Basket.DAL
{
    public interface IBasketFunctions
    {
        //*** The database connection has to be opened automatically
        //*** during instantiation of the database manager. So Database
        //*** connection will be active for the lifetime of the manager.
        //*** When the manager no longer used then it has to be closed.
        //*** There is no database open function to restrict frequent database
        //*** connection creation.

        DataTable GetReportRelationName(string reportCode);

    }
}